package app;

import core.ShowHandler;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import ports.driver.Handler;
import ports.driver.http.HttpDriver;
import ports.monitor.AppMonitor;
import ports.monitor.servo.MonitoringDestination;
import ports.monitor.servo.ServoMonitor;
import ports.monitor.servo.cloudwatch.CloudWatchDestination;
import ports.monitor.servo.log.LogDestination;
import ports.teller.Teller;
import ports.teller.sqs.SQSTeller;

import static java.lang.System.getenv;

@SpringBootApplication
public class App {

    private final static String RUNTIME_ENV = "runtimeEnvironment";
    private final static String RUNTIME_ENV_LOCAL = "local";

    private final static String DEPLOYMENT_COLOR = "deploymentColor";
    private final static String COLOR_NONE = "none";

    private static String getRuntime() {
        final String e = getenv(RUNTIME_ENV);
        if (StringUtils.isEmpty(e)) {
            return RUNTIME_ENV_LOCAL;
        }

        return e;
    }

    private static String getDeploymentColor() {
        final String c = getenv(DEPLOYMENT_COLOR);
        if (StringUtils.isEmpty(c)) {
            return COLOR_NONE;
        }

        return c;
    }

    private static boolean isLocal() {
        return getRuntime().equals(RUNTIME_ENV_LOCAL);
    }

    @Bean Teller.Iface teller() {
        return new SQSTeller("");
    }

    @Bean MonitoringDestination servoDestination(){
        if(isLocal()) {
            return new LogDestination();
        } else {
            return new CloudWatchDestination();
        }
    }

    @Bean AppMonitor.Iface monitor() {
        return new ServoMonitor(servoDestination(), "show-n-tell", 30, 2, getRuntime(), getDeploymentColor());
    }

    @Bean Handler.Iface handler() {
        return new ShowHandler(teller(), monitor());
    }

    @Bean HttpDriver driver() {
        return new HttpDriver(handler(), Integer.parseInt(System.getenv("PORT")));
    }

    private static final Logger log = LoggerFactory.getLogger(App.class);

    public static void main(String[] args) throws Exception {
        ApplicationContext ctx = SpringApplication.run(App.class);
        HttpDriver driver = ctx.getBean(HttpDriver.class);
        driver.start();
        log.info("gateway started");
    }
}

