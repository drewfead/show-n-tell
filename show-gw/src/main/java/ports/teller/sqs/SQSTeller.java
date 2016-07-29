package ports.teller.sqs;

import com.amazonaws.auth.DefaultAWSCredentialsProviderChain;
import com.amazonaws.services.sqs.AmazonSQS;
import com.amazonaws.services.sqs.AmazonSQSClient;
import com.amazonaws.services.sqs.model.SendMessageRequest;
import org.apache.thrift.TException;
import org.apache.thrift.TSerializer;
import ports.teller.Teller;
import show.Show;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import java.util.Base64;

public class SQSTeller implements Teller.Iface {

    private final String queueUrl;

    public SQSTeller(String queueUrl) {
        this.queueUrl = queueUrl;
    }

    private AmazonSQS sqs;

    @PostConstruct
    public void init() {
        sqs = new AmazonSQSClient(new DefaultAWSCredentialsProviderChain());
    }

    public void accept(Show show) throws TException {
        byte[] data = new TSerializer().serialize(show);
        String base64 = Base64.getEncoder().encodeToString(data);
        SendMessageRequest send = new SendMessageRequest();
        send.setQueueUrl(queueUrl);
        send.setMessageBody(base64);
        sqs.sendMessage(send);
    }

    @PreDestroy
    public void stop() {
        if (sqs != null) {
            sqs.shutdown();
        }
    }
}
