Look at the bind statement in the frontend section there: rather than binding to the wildcard address (bind *:80), we're binding specifically to the VIP address.

Now, you might be wondering: isn't that going to result in an error when haproxy starts up on the node that doesn't currently own the VIP? 
You might expect to see something like:

[ALERT]    (6559) : Starting frontend main: cannot bind socket (Cannot
assign requested address) [192.168.122.201:80]
Normally, you would be correct! But in this case, we're going to set the net.ipv4.ip_nonlocal_bind sysctl to 1:

sysctl -w net.ipv4.ip_nonlocal_bind=1
