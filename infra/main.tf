# Crear la VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/22"  # VPC CIDR Block que abarca los tres grupos
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "MyVPC"
  }
}

# Crear las Subredes Públicas
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.64/26"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet 1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.64/26"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet 2"
  }
}

resource "aws_subnet" "public_subnet_3" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.3.64/26"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet 3"
  }
}

# Crear las Subredes Privadas
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.128/26"
  availability_zone       = "us-east-1a"
  tags = {
    Name = "Private Subnet 1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.128/26"
  availability_zone       = "us-east-1b"
  tags = {
    Name = "Private Subnet 2"
  }
}

resource "aws_subnet" "private_subnet_3" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.3.128/26"
  availability_zone       = "us-east-1c"
  tags = {
    Name = "Private Subnet 3"
  }
}

# Crear una puerta de enlace de Internet (para las subredes públicas)
resource "aws_internet_gateway" "my_internet_gateway" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyInternetGateway"
  }
}

# Crear la tabla de rutas para las subredes públicas
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
}

# Crear una ruta para la tabla de rutas públicas
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_internet_gateway.id
}

# Asociar las subredes públicas a la tabla de rutas
resource "aws_route_table_association" "public_association_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_association_3" {
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.public_route_table.id
}

# Crear un grupo de seguridad para permitir acceso SSH (puerto 22)
resource "aws_security_group" "my_security_group" {
  name        = "my_security_group"
  description = "Allow SSH access"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permite acceso desde cualquier IP. Cambia esto por tu IP si es necesario
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Permite todo el tráfico de salida
  }

  tags = {
    Name = "my_security_group"
  }
}

# Crear una instancia EC2
resource "aws_instance" "my_instance" {
  ami           = "ami-05b1a50d6798f63cb"  # Reemplaza con el ID de la AMI (por ejemplo, Amazon Linux 2)
  instance_type = "t3.micro"               # Tipo de instancia (puedes cambiarlo según tus necesidades)
  subnet_id     = aws_subnet.public_subnet_1.id
  security_group = aws_security_group.my_security_group.id

  # Asociar una IP pública
  associate_public_ip_address = true

  tags = {
    Name = "MyEC2Instance"
  }
}
