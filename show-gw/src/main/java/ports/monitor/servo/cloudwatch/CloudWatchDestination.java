package ports.monitor.servo.cloudwatch;

import com.amazonaws.auth.DefaultAWSCredentialsProviderChain;
import com.amazonaws.services.cloudwatch.AmazonCloudWatch;
import com.amazonaws.services.cloudwatch.AmazonCloudWatchClient;
import com.netflix.servo.publish.CounterToRateMetricTransform;
import com.netflix.servo.publish.MetricObserver;
import com.netflix.servo.publish.cloudwatch.CloudWatchMetricObserver;
import ports.monitor.servo.MonitoringDestination;

import javax.annotation.PostConstruct;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.TimeUnit;

public class CloudWatchDestination implements MonitoringDestination{

	private static final String NAMESPACE_PREFIX = "App/";

	private AmazonCloudWatch cloudWatch;

	@PostConstruct
	public void init() { cloudWatch = new AmazonCloudWatchClient(new DefaultAWSCredentialsProviderChain()); }

	public boolean shouldStart() {
		return cloudWatch != null;
	}

	private MetricObserver staticObserver(String monitorId) {
		return new CloudWatchMetricObserver(monitorId + ":Static", NAMESPACE_PREFIX + "Static", cloudWatch);
	}

	private MetricObserver rateObserver(String monitorId, long hearbeat, int beatsPerWindow){
		return new CounterToRateMetricTransform(
			new CloudWatchMetricObserver(monitorId + ":Rate", NAMESPACE_PREFIX + "Activity", cloudWatch),
			beatsPerWindow * hearbeat,
			hearbeat,
			TimeUnit.MILLISECONDS
		);
	}

	public List<MetricObserver> observers(String monitorId, long heartbeat, int beatsPerWindow) {

		return Arrays.asList(
			rateObserver(monitorId, heartbeat, beatsPerWindow),
			staticObserver(monitorId)
		);
	}
}
