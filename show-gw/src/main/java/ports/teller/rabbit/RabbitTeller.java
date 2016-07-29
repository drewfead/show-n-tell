package ports.teller.rabbit;

import com.rabbitmq.client.AMQP;
import com.rabbitmq.client.Channel;
import com.rabbitmq.client.Connection;
import com.rabbitmq.client.ConnectionFactory;
import org.apache.thrift.TException;
import org.apache.thrift.TSerializer;
import ports.teller.Teller;
import show.Show;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import java.util.HashMap;

public class RabbitTeller implements Teller.Iface {

    private static String exchange = "local-tells";
    private static  String routingKey = "tells.inbound";

    private ConnectionFactory cf;
    private Connection c;

    @PostConstruct
    public void init() {
        cf = new ConnectionFactory();
        cf.setUsername("guest");
        cf.setPassword("guest");
        cf.setVirtualHost("/");
        cf.setHost("localhost");

        try {
            c = cf.newConnection();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public void accept(Show show) throws TException {

        Connection conn = null;
        Channel channel = null;
        try {
            conn = cf.newConnection();
            channel = conn.createChannel();
            channel.exchangeDeclare(exchange, "direct", true);

            AMQP.BasicProperties properties = new AMQP.BasicProperties.Builder()
                .headers(new HashMap())
                .build();

            TSerializer s = new TSerializer();
            byte[] body = s.serialize(show);

            channel.basicPublish(exchange, routingKey, properties, body);
        }
        catch (Exception e) {
            throw new TException(e);
        }
        finally {
            if (channel != null) { try { channel.close(); } catch (Exception e) {} }
            if (conn != null) { try { conn.close(); } catch (Exception e) {} }
        }
    }

    @PreDestroy
    public void close() {
        try {
            c.close();
        }
        catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
