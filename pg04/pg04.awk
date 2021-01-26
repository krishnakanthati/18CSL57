BEGIN{num_of_pkts = 0;}
{
if($1 == "r" && $3 == "_1_" && $4 == "AGT" && $7 == "tcp")
{
    num_of_pkts=num_of_pkts + $8;
}
}
END{
    throughput=num_of_pkts *8/$2/1000000;
    printf("\n\n\tthroughput=%fMbps\n\n\n",throughput);
}