unless AdminUser.exists?(email: ENV.fetch('ADMIN_EMAIL', 'admin@example.com'))
  AdminUser.create!(email: ENV.fetch('ADMIN_EMAIL', 'admin@example.com'),
                    password: ENV.fetch('ADMIN_PASSWORD', 'password'),
                    password_confirmation: ENV.fetch('ADMIN_PASSWORD', 'password'))
end
