unless AdminUser.exists?(email: ENV.fetch('ADMIN_EMAIL', 'admin@example.com'))
  admin_password = ENV.fetch('ADMIN_PASSWORD', 'password1234')
  AdminUser.create!(email: ENV.fetch('ADMIN_EMAIL', 'admin@example.com'),
                    password: admin_password,
                    password_confirmation: admin_password)
end
