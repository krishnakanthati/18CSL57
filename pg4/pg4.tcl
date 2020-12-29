# create simulator
set ns [new Simulator]

# open trace and NAM trace file
set ntrace [open pg4.tr w]
$ns trace-all $ntrace

set namfile [open pg4.nam w]
$ns namtrace-all $namfile

# finish procedure
proc Finish {} {
    global ns ntrace namfile
    # dump all trace data and close the file
    $ns flush-trace
    close $ntrace
    close $namfile
    # execute the nam animation file
    exec nam pg4.nam &
    # find number of ping packets dropped
    puts "The number of ping packets dropped are"
    exec grep "^d" pg4.tr | cut -d " " -f 5 | grep -c "ping" &
    exit 0
}

# create six nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

# connect the nodes
$ns duplex-link $n0 $n1 0.01Mb 15ms DropTail
$ns duplex-link $n1 $n2 0.01Mb 15ms DropTail
$ns duplex-link $n2 $n3 0.01Mb 15ms DropTail
$ns duplex-link $n3 $n4 0.01Mb 15ms DropTail
$ns duplex-link $n4 $n5 0.01Mb 15ms DropTail

# define the recv functions for the class 'Agent/Ping'
Agent/Ping instproc recv {from rtt} {
    $self instvar node_
    puts "node [$node_ id] received ping answer from $from with round trip time $rtt ms"
}

# create two ping agents and attach them to n(0)4 & n(5)
set p0 [new Agent/Ping]
$ns attach-agent $n0 $p0

set p1 [new Agent/Ping]
$ns attach-agent $n5 $p1

# create congestion
# generate a huge CBR traffic between n(2) & n(4)
$ns connect $p0 $p1
$ns queue-limit $n0 $n1 2

set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0

set sink0 [new Agent/TCPSink]
$ns attach-agent $n5 $sink0
$ns connect $tcp0 $sink0

# Apply CBR traffic over TCP
set ftp0 [new Application/FTP]
$ftp0 set packetSize_ 500

$ftp0 attach-agent $tcp0

# schedule events
$ns at 0.2 "$p0 send"
$ns at 0.4 "$p1 send"
$ns at 0.4 "$ftp0 start"
$ns at 0.8 "$p0 send"
$ns at 1.0 "$p1 send"
$ns at 1.2 "$ftp0 stop"
$ns at 1.4 "$p0 send"
$ns at 1.6 "$p1 send"
$ns at 1.8 "Finish"

# run the simulation
$ns run
