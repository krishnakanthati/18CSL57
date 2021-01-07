set ns [new Simulator]

set ntrace [open pg3.tr w]
$ns trace-all $ntrace
set namfile [open pg3.nam w]
$ns namtrace-all $namfile

$ns color 1 red

proc finish {} {
    global ns ntrace namfile
    $ns flush-trace
    close $ntrace
    close $namfile
    exec nam pg3.nam &
    exec echo "The number of packet drop is " &
    exec grep -c "^d" pg3.tr &
    exit 0
}

set n0 [$ns node]
$n0 color red
set n1 [$ns node]
$n1 color green 
set n2 [$ns node]
$n2 color blue

$ns duplex-link $n0 $n1 2.0Mb 10ms DropTail
$ns duplex-link $n1 $n2 3.0Mb 10ms DropTail
$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n1 $n2 orient right
$ns queue-limit $n0 $n1 15
$ns queue-limit $n1 $n2 15

set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
set sink0 [new Agent/TCPSink]
$ns attach-agent $n2 $sink0

$ns connect $tcp0 $sink0
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $tcp0

$tcp0 set fid_ 1
$ns at 0.0 "$cbr0 start"
$ns at 5.0 "finish"

$ns run
