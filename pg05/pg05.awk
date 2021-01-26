BEGIN {n=0;}
{
if($1 == "r")
{
    n = n + $6;
    printf("%f %d\n", $2, n) > "gsm.xg"
}
}
END{}
