namespace java ports.teller

include "show/show.thrift"

service Teller {
    void accept(1: show.Show show);
}


