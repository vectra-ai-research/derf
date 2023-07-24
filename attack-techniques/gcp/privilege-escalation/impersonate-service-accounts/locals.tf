locals {
  service_account_emails = tolist(google_service_account.service_account[*].email)
}

