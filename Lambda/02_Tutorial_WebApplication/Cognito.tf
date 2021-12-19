resource "aws_cognito_user_pool" "Cognito_User_Pool" {
  name = "ib07441-user-pool"
}

resource "aws_cognito_user_pool_client" "Cognito_User_Pool_Client" {
  name = "ib07441-user-pool-client"

  user_pool_id = aws_cognito_user_pool.Cognito_User_Pool.id

  generate_secret     = false
}