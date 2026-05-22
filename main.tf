#Create ECR Repository
resource "aws_ecr_repository" "app_repo" {
  name = var.ecr_repo_name
}

#IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "jenkins-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}


#Attach Policy
resource "aws_iam_role_policy_attachment" "ecr_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}


#Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "jenkins-instance-profile"
  role = aws_iam_role.ec2_role.name
}



# ECS Cluster
resource "aws_ecs_cluster" "app_cluster" {
  name = "sample-ecs-cluster"
}


# Creating a Security Group - Which Allows ALL Traffic
resource "aws_security_group" "ec2_sg" {
  name        = "allow-all-Traffic-sg"
  description = "Allow all inbound and outbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" 
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-all-Traffic-sg"
  }
}




# Get latest Amazon Linux AMI, What kind of AMI

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}



# Creating sample EC2 Instance

resource "aws_instance" "shivani_sample_ec2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "shivani_sample_ec2"
  }
}


#Task Definition: Run this Docker image from ECR
resource "aws_ecs_task_definition" "app_task" {
  family                   = "app-task"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn      = aws_iam_role.ec2_role.arn

  container_definitions = jsonencode([
    {
      name      = "app-container"
      image     = "411233202089.dkr.ecr.us-east-2.amazonaws.com/app123:v0.1"
      essential = true

      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
    }
  ])
}


#Keeps your app alive: If container crashes, ECS restarts it: Always maintains 1 running container
resource "aws_ecs_service" "app_service" {
  name            = "app-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
  launch_type     = "EC2"

  depends_on = [aws_instance.shivani_sample_ec2]
}



