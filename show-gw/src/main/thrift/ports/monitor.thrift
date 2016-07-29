namespace java ports.monitor

union Metric {
    1: i64 latency
    2: string rejection
    3: string failure
}

service AppMonitor {
    void watch(1: Metric metric, 2: i64 whenMillis);
}

const string AVG_PROCESSING_TIME = "Latency"
const string THROUGHPUT = "Success"
const string REJECTION_RATE = "Reject"
const string FAILURE_RATE = "Failure"
