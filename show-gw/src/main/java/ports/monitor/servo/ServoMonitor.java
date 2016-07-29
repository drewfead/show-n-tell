package ports.monitor.servo;

import com.netflix.servo.DefaultMonitorRegistry;
import com.netflix.servo.annotations.DataSourceType;
import com.netflix.servo.monitor.BasicCounter;
import com.netflix.servo.monitor.BasicInformational;
import com.netflix.servo.monitor.Counter;
import com.netflix.servo.monitor.MonitorConfig;
import com.netflix.servo.monitor.StatsTimer;
import com.netflix.servo.publish.BasicMetricFilter;
import com.netflix.servo.publish.MetricObserver;
import com.netflix.servo.publish.MonitorRegistryMetricPoller;
import com.netflix.servo.publish.PollRunnable;
import com.netflix.servo.publish.PollScheduler;
import com.netflix.servo.stats.StatsConfig;
import com.netflix.servo.tag.BasicTag;
import com.netflix.servo.tag.Tag;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.thrift.TException;
import ports.monitor.AppMonitor;
import ports.monitor.Metric;
import ports.monitor.monitorConstants;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.TimeUnit;

public class ServoMonitor implements AppMonitor.Iface{
	private static final Log log = LogFactory.getLog(ServoMonitor.class);

	private MonitoringDestination dest;

	private String monitorId;
	private long heartbeat;
	private int beatsPerWindow;

	// metrics
	private Counter numProcessed;
	private Counter numFailed;
	private Counter numRejects;
	private StatsTimer latency;

	@PostConstruct
	public void start() throws TException {
		if(!dest.shouldStart()) {
			log.info("Not starting ServoMonitor");
			return;
		}

		DefaultMonitorRegistry.getInstance().register(numProcessed);
		DefaultMonitorRegistry.getInstance().register(numFailed);
		DefaultMonitorRegistry.getInstance().register(numRejects);
		DefaultMonitorRegistry.getInstance().register(latency);

		final List<MetricObserver> observers = dest.observers(monitorId, heartbeat, beatsPerWindow);

		PollScheduler.getInstance().start();

		PollScheduler.getInstance().addPoller(
				new PollRunnable(
						new MonitorRegistryMetricPoller(),
						BasicMetricFilter.MATCH_ALL,
						observers
				),

				heartbeat,
				TimeUnit.MILLISECONDS
		);

		log.info("Started");
	}

	public ServoMonitor(MonitoringDestination dest, String monitorId, long heartbeat, int beatsPerWindow,
	                    String runtime, String deploymentColor){
		this.dest = dest;
		this.monitorId = monitorId;
		this.heartbeat = heartbeat;
		this.beatsPerWindow = beatsPerWindow;

		final List<Tag> commonTags = Arrays.asList(
				new BasicTag("Color", deploymentColor),
				new BasicTag("Runtime", runtime),
				new BasicTag("AppName", "keymetric-gateway")
		);

		initMetrics(commonTags);
	}

	private void initMetrics(List<Tag> commonTags) {
		latency = new StatsTimer(
			MonitorConfig.builder(monitorConstants.AVG_PROCESSING_TIME)
				.withTags(commonTags)
				.build(),
			new StatsConfig.Builder()
				.withComputeFrequencyMillis(beatsPerWindow * heartbeat)
				.withPublishMean(true)
				.withPublishCount(false)
				.withPublishTotal(false)
				.withPercentiles(new double[0])
				.build()
		);

		// Tag counters for rate transformation
		List<Tag> counterTags = new ArrayList<>(commonTags);
		counterTags.add(new BasicTag(DataSourceType.KEY, DataSourceType.COUNTER.getValue()));

		numProcessed = new BasicCounter(
			MonitorConfig.builder(monitorConstants.THROUGHPUT)
                 .withTags(counterTags)
                 .build()
		);

		numFailed = new BasicCounter(
            MonitorConfig.builder(monitorConstants.FAILURE_RATE)
                 .withTags(counterTags)
                 .build()
		);

		numRejects = new BasicCounter(
            MonitorConfig.builder(monitorConstants.REJECTION_RATE)
                .withTags(counterTags)
                .build()
		);
	}

	@Override
	public void watch(Metric data, long whenMillis) throws TException {

		if(data.isSetFailure()) {
			numFailed.increment();

		}else if(data.isSetRejection()){
			numRejects.increment();

		} else if (data.isSetLatency()) {
			numProcessed.increment();
			latency.record(data.getLatency(), TimeUnit.MILLISECONDS);
		}
	}

	@PreDestroy
	public void cleanup() {
		log.info("Stopping...");
		try {
			if(PollScheduler.getInstance().isStarted()) {
				PollScheduler.getInstance().stop();
			}
			log.info("Stopped.");
		} catch (Exception e) {
			log.error("Couldn't stop metric poller");
		}
	}
}
