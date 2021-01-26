set ns [new Simulator]

set ntrace [open pg01.tr w]
$ns trace-all $ntrace

set namfile [open pg01.nam w]
$ns namtrace-all $namfile

proc Finish {} {
    global ns ntrace namfile
    $ns flush-trace
    close $ntrace
    close $namfile
    exec nam pg01.nam &
    exec echo "The number of packet drops is: " &
    exec grep -c "^d" pg01.tr &
    exit 0
}

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail
$ns queue-limit $n0 $n1 10
$ns queue-limit $n1 $n2 10

set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp

set sink [new Agent/TCPSink]
$ns attach-agent $n2 $sink
$ns connect $tcp $sink

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $tcp

$ns at 0.0 "$cbr start"
$ns at 5.0 "Finish"

$ns run