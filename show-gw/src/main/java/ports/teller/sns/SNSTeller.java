package ports.teller.sns;

import com.amazonaws.auth.DefaultAWSCredentialsProviderChain;
import com.amazonaws.services.sns.AmazonSNSClient;
import com.amazonaws.services.sns.model.PublishRequest;
import org.apache.thrift.TException;
import org.apache.thrift.TSerializer;
import ports.teller.Teller;
import show.Show;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import java.util.Base64;

public class SNSTeller implements Teller.Iface {

    private AmazonSNSClient sns;
    private final String topicArn;

    public SNSTeller(String topicArn) {
        this.topicArn = topicArn;
    }

    @PostConstruct
    public void init() {
        sns = new AmazonSNSClient(new DefaultAWSCredentialsProviderChain());
    }

    public void accept(Show show) throws TException {
        byte[] data = new TSerializer().serialize(show);
        String base64 = Base64.getEncoder().encodeToString(data);
        PublishRequest request = new PublishRequest(topicArn, base64);
        sns.publish(request);
    }

    @PreDestroy
    public void stop() {
        if (sns != null) {
            sns.shutdown();
        }
    }
}
