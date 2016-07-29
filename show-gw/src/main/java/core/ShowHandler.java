package core;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.apache.thrift.TException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import ports.driver.Handler;
import ports.driver.ParseFailure;
import ports.driver.SystemFailure;
import ports.driver.ValidationFailure;
import ports.monitor.AppMonitor;
import ports.monitor.Metric;
import ports.teller.Teller;
import show.Show;

import java.io.IOException;
import java.nio.ByteBuffer;

import static org.apache.commons.lang3.StringUtils.trimToNull;

public class ShowHandler implements Handler.Iface {

    private static final Logger log = LoggerFactory.getLogger(ShowHandler.class);

    private static final ObjectMapper mapper = new ObjectMapper();
    static {
        mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
    }

    private final Teller.Iface teller;
    private final AppMonitor.Iface monitor;

    public ShowHandler(Teller.Iface teller, AppMonitor.Iface monitor) {
        this.teller = teller;
        this.monitor = monitor;
    }

    private static String require(String s) throws ValidationFailure {
        s = trimToNull(s);
        if (s == null) {
            throw new ValidationFailure();
        }
        return s;
    }

    private static <T> T require(T object) throws ValidationFailure {
        if (object == null) {
            throw new ValidationFailure();
        }
        return object;
    }

    private static class Input {
        public String thing;
    }

    private static Input parse(byte[] raw) throws ParseFailure {
        final Input in;
        try {
            in = mapper.readValue(raw, Input.class);
        } catch (IOException e) {
            throw new ParseFailure();
        }
        return in;
    }

    private static Show show(Input in) throws ValidationFailure {
        final Show show = new Show();

        require(in);

        require(in.thing);
        show.setDescription(in.thing);

        return show;
    }

    private static final String MDC_TRACE_ID = "trace_id";

    public void handle(String traceId, ByteBuffer in) throws ParseFailure, ValidationFailure, SystemFailure, TException {

        Exception e = null;
        long startTime = System.currentTimeMillis();
        byte[] rawData;
        try {
            MDC.put(MDC_TRACE_ID, traceId);
            {
                rawData = new byte[in.remaining()];
                in.get(rawData);
            }

            log.info("received show");

            try {
                final Input input = parse(rawData);
                final Show show = show(input);
                teller.accept(show);

            } catch (Exception ex) {
                e = ex;
                throw e;
            }

            log.info("dispatched tells to teller");
        }
        catch (Exception outer) {
            log.error("failed to dispatch tell to teller", outer);
            e = outer;
            throw new SystemFailure();
        }
        finally {
            Metric m = new Metric();
            if(e != null){
                if(e instanceof ParseFailure || e instanceof ValidationFailure){
                    m.setRejection(e.getClass().getName());
                }else{
                   m.setFailure(e.getClass().getName());
                }
            }else{
                m.setLatency(System.currentTimeMillis() - startTime);
            }

            monitor.watch(m, startTime);
            MDC.remove(MDC_TRACE_ID);
        }
    }
}
