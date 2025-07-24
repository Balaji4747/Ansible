# key pair 

resource "aws_key_pair" "my_key" {
  key_name   = "terra-key-ansible"
  public_key = file("terra-key-ansible.pub")

}

#   vpc and security group 

resource "aws_default_vpc" "default" {
  
}

resource "aws_security_group" "my_security_group" {
  name = "automate-sg"
  description = "This will add a TF genereted security group"
  vpc_id = aws_default_vpc.default.id   #interpolation 

  # Inbound rule 
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH open"
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP open"
  }

  ingress {
    from_port = 8000
    to_port = 8000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Flask-app"
  }

  # Out Bound Rule
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All access open"
  }
  
  tags = {
    name = "automate-sg"
  }
}

# EC2 Instance

resource "aws_instance" "my_instance" {
  # count = 2   # meta argument
  for_each = tomap({
    TWS-JUNOON-Master = "ami-0d1b5a8c13042c939",  #ubuntu
    TWS-JUNOON-1 = "ami-0d1b5a8c13042c939",       # ubuntu
    TWS-JUNOON-2 = "ami-068d5d5ed1eeea07c",       # Red Hat
    TWS-JUNOON-3 = "ami-0cd582ee8a22cc7be"        # amazon linux
  })

  # meta argument 
  depends_on = [ aws_security_group.my_security_group, aws_key_pair.my_key ]
  key_name = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.my_security_group.name]
  instance_type = "t2.micro"
  ami = each.value


  root_block_device {
    volume_size = 10
    volume_type = "gp3"

  }
  tags = {
    Name = each.key
  }
}

