package ports.monitor.servo;

import com.netflix.servo.publish.MetricObserver;

import java.util.List;

public interface MonitoringDestination {
	boolean shouldStart();
	List<MetricObserver> observers(String monitorId, long heartbeat, int beatsPerWindow);
}
