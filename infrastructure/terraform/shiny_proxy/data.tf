data "aws_instance" "bastion" {
  filter {
    name = "tag:Name"
    values = ["bastion"]
  }
}


data  "aws_security_group" "bastion_sg" {
  filter {
    name = "tag:Name"
    values = ["bastion"]
  }
}




data "aws_subnet" "private" {
  vpc_id = "${var.vpc_id}"
  count = "${length(var.azs)}"
  availability_zone = "${element(var.azs,count.index)}"
  tags {
    Name = "${var.environment}-vpc-subnet-private-${element(var.azs,count.index)}"
  }
}



data "aws_subnet" "public" {
  vpc_id = "${var.vpc_id}"
  count = "${length(var.azs)}"
  availability_zone = "${element(var.azs, count.index)}"
  tags {
    "Name" = "${var.environment}-vpc-subnet-public-${element(var.azs, count.index)}"
  }

}
