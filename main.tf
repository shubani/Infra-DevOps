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

#EC2 Instance
resource "aws_instance" "jenkins_server" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux (update if needed)
  instance_type = var.instance_type

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "Jenkins-Server"
  }
}




