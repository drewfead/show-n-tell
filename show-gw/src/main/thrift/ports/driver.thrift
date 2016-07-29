namespace java ports.driver

exception ValidationFailure {}

exception SystemFailure {}

exception ParseFailure {}

service Handler {
    void handle(1: string traceId, 2: binary data)
        throws (1: ParseFailure p, 2: ValidationFailure v, 3: SystemFailure s);
}



