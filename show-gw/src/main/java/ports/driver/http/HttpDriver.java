package ports.driver.http;

import com.amazonaws.util.IOUtils;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.eclipse.jetty.server.Request;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.handler.AbstractHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import ports.driver.Handler;
import ports.driver.ParseFailure;
import ports.driver.ValidationFailure;
import show.Show;

import javax.annotation.PreDestroy;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.UUID;

public class HttpDriver {

    private final Handler.Iface handler;
    private static final Logger log = LoggerFactory.getLogger(HttpDriver.class);

    private Server server;
    private int port;

    public HttpDriver(Handler.Iface handler, int port) {
        this.handler = handler;
        this.port = port;
    }

    private static final ObjectMapper mapper = new ObjectMapper();

    private static class Output {
        public String traceId;
        public String message;
    }

    public void start() throws Exception {
        server = new Server(port);
        server.setHandler(new AbstractHandler() {
            public void handle(
                    String s, Request r, HttpServletRequest request, HttpServletResponse response)
                    throws IOException, ServletException {
                String traceId = UUID.randomUUID().toString();
                String responseMessage = "";
                int responseCode = 0;
                try {
                    byte[] data = IOUtils.toByteArray(r.getInputStream());
                    handler.handle(traceId, ByteBuffer.wrap(data));
                    responseCode = HttpServletResponse.SC_OK;
                    responseMessage = "Show posted successfully.";
                } catch (ParseFailure f) {
                    responseCode = HttpServletResponse.SC_BAD_REQUEST;
                    responseMessage = "Invalid JSON.";
                } catch (ValidationFailure f) {
                    responseCode = HttpServletResponse.SC_BAD_REQUEST;
                    responseMessage = "Invalid data structure.";
                } catch (Exception e) {
                    responseCode = HttpServletResponse.SC_INTERNAL_SERVER_ERROR;
                    responseMessage = "An unknown error occurred: " + e.getLocalizedMessage();
                }
                finally {
                    final Output out = new Output();
                    out.traceId = traceId;
                    out.message = responseMessage;

                    mapper.writeValue(response.getOutputStream(), out);
                    response.setStatus(responseCode);
                    try {
                        response.getOutputStream().flush();
                    } catch (IOException e) {
                        throw e;
                    }
                    r.setHandled(true);
                }
            }
        });
        server.start();
    }

    @PreDestroy
    public void stop() throws Exception {
        if (server != null){
            server.stop();
        }
    }
}