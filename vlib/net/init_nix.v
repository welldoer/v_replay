module net

#include <sys/socket.h>
#include <unistd.h>
#include <netinet/in.h>
#include <netdb.h>
#include <errno.h>

fn error_code() int {
    return C.errno
}
