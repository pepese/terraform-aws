output "vpc" {
  value = {
    id = aws_vpc.vpc.id
  }
}

output "subnet" {
  value = {
    public_1a_id    = aws_subnet.public_1a.id
    public_1c_id    = aws_subnet.public_1c.id
    public_1d_id    = aws_subnet.public_1d.id
    protected_1a_id = aws_subnet.protected_1a.id
    protected_1c_id = aws_subnet.protected_1c.id
    protected_1d_id = aws_subnet.protected_1d.id
    private_1a_id   = aws_subnet.private_1a.id
    private_1c_id   = aws_subnet.private_1c.id
    private_1d_id   = aws_subnet.private_1d.id
  }
}