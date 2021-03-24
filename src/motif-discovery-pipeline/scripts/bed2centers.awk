BEGIN{
    OFS = "\t";
}

!/^#/{
    print $1, $4-1, $4;
}
