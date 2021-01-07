# create simulator
set ns [new Simulator]

# open trace file & NAM file
set ntrace [open pg2.tr w]
$ns trace-all $ntrace
set namfile [open pg2.nam w]
$ns namtrace-all $namfile

# finish procedure
proc finish {} {
    global ns ntrace namfile
    # dump all the trace data & close the files 
    $ns flush-trace
    close $ntrace
    close $namfile
    
    exec nam pg2.nam &
    # execute the nam animation file nam pg2.nam &
    # show the number of packet dropped
    exec echo "The number of packet drop is " &
    exec grep -c "^d" pg2.tr &
    exit 0
}

# create 3 node
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

# create links between nodes
# you need to modify the bandwidth to observe the variation in packet drop
$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail

# make the link orientation
$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n1 $n2 orient right

# set queue size
# you can modify the queue length as well to observe the variation in packet drop
$ns queue-limit $n0 $n1 10
$ns queue-limit $n1 $n2 10

# set up a transport layer connection 
set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
set sink0 [new Agent/TCPSink]
$ns attach-agent $n2 $sink0
$ns connect $tcp0 $sink0

# set up an application layer traffic
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $tcp0

# schedule events
$ns at 0.0 "$cbr0 start"
$ns at 5.0 "finish"

# Run the simulator
$ns run
