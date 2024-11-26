output "arn_bucket_demo"{
    description = "Valeur de l'ARN du bucket créé par terraform"
    value= aws_s3_bucket.example.arn 
}