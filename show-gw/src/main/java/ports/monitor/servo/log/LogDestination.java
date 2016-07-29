package ports.monitor.servo.log;

import com.netflix.servo.Metric;
import com.netflix.servo.publish.BaseMetricObserver;
import com.netflix.servo.publish.CounterToRateMetricTransform;
import com.netflix.servo.publish.MetricObserver;
import com.netflix.servo.util.Throwables;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import ports.monitor.servo.MonitoringDestination;
import ports.monitor.servo.ServoMonitor;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.TimeUnit;

public class LogDestination implements MonitoringDestination{

	private static class LoggingObserver extends BaseMetricObserver {
		private static final Log log = LogFactory.getLog(ServoMonitor.class);

		public LoggingObserver(String name){ super(name); }

		private static String logFor(Metric m) {
			return "[" + LocalDateTime.ofInstant(Instant.ofEpochMilli(m.getTimestamp()), ZoneId.systemDefault())
					+ "]: name=" + m.getConfig().getName() + ", tags=" + m.getConfig().getTags().asMap() + ", "
					+ "value=" + m.getValue();
		}

		@Override
		public void updateImpl(List<Metric> metrics) {
			try {
				// using this implementation because it more closely matches the CloudWatchMetricObserver's impl
				while (!metrics.isEmpty()) {
					Metric m = metrics.remove(0);
					if(log.isDebugEnabled()) {
						log.debug(logFor(m));
					}
				}
			} catch (Throwable t) {
				incrementFailedCount();
				throw Throwables.propagate(t);
			}

		}
	}

	public boolean shouldStart() { return true; }

	private MetricObserver staticObserver(String monitorId) { return new LoggingObserver(monitorId + ":static"); }

	private MetricObserver rateObserver(String monitorId, long heartbeat, int beatsPerWindow){
		return new CounterToRateMetricTransform(
			new LoggingObserver(monitorId + ":activity"),
				beatsPerWindow * heartbeat * 1000,
				TimeUnit.SECONDS
		);
	}

	public List<MetricObserver> observers(String monitorId, long heartbeat, int beatsPerWindow) {

		return Arrays.asList(
				rateObserver(monitorId, heartbeat, beatsPerWindow),
				staticObserver(monitorId)
		);
	}
}
