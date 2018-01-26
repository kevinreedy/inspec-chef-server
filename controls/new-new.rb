api_fqdn                = attribute('api_fqdn', default: 'localhost', description: 'The API FQDN for the Chef Server')
client_name             = attribute('client_name', default: 'pivotal', description: 'The API Client of the Chef Server Admin')
signing_key_filename    = attribute('signing_key_filename', default: '/etc/opscode/pivotal.pem', description: 'Private key of the API Client')
trusted_certs_dir       = attribute('trusted_certs_dir', default: '/etc/chef/trusted_certs_dir', description: 'Loation for trusted SSL certificates')
count_cookbook_versions = attribute('count_cookbook_versions', default: false, description: 'Whether to count all cookbook versions, could be long running')

org_list = command('chef-server-ctl org-list').stdout.split

control 'Has a version of Chef Server that works with Automate\'s data collector' do
  desc '
    Older versions of Chef Server cannot send run and compliance
    information to Chef Automate
  '

  describe package('chef-server-core') do
    its('version') { should cmp >= '12.11.0' }
  end
end
