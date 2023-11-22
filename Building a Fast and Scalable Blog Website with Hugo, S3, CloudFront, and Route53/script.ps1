cd "\public_directory"

echo "Cleaning Public Folder"
Remove-Item -Path "\public_directory" -Recurse
echo "Public Folder cleaned"

echo "Building Site.."
hugo
echo "Site Built Successfully"

echo "Cleaning S3 Bucket.."
aws s3 rm s3://<BUCKET_NAME> --recursive
echo "S3 Bucket Cleaned"

echo "Uploading to S3 Bucket.."
aws s3 cp "\public_directory" s3://<BUCKET_NAME> --recursive
echo "Upload to S3 Bucket Complete"