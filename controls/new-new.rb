api_fqdn                = attribute('api_fqdn', default: 'localhost', description: 'The API FQDN for the Chef Server')
client_name             = attribute('client_name', default: 'pivotal', description: 'The API Client of the Chef Server Admin')
signing_key_filename    = attribute('signing_key_filename', default: '/etc/opscode/pivotal.pem', description: 'Private key of the API Client')
trusted_certs_dir       = attribute('trusted_certs_dir', default: '/etc/chef/trusted_certs_dir', description: 'Loation for trusted SSL certificates')

org_list = command('chef-server-ctl org-list').stdout.split

control 'Has a version of Chef Server that works with Automate\'s data collector' do
  desc '
    Older versions of Chef Server cannot send run and compliance
    information to Chef Automate.
  '

  describe package('chef-server-core') do
    its('version') { should cmp >= '12.11.0' }
  end
end

control 'Chef Clients are a supported version' do
  desc '
    Chef Client 12 and earlier are at End-of-Life. Ensure no
    clients are running unsupported versions.
  '

  org_list.each do |org|
    opts = "-s https://#{api_fqdn}/organizations/#{org}"
    opts << " -k #{signing_key_filename} -u #{client_name}"
    opts << " --config-option trusted_certs_dir=#{trusted_certs_dir} 2>/dev/null"

    client_versions = JSON.parse(command("knife search node '*:*' -a chef_packages.chef.version -Fj #{opts}").stdout)['rows']

    client_versions.each do |node|
      describe node do
        its('values.first.values.first') { should cmp >= '13.0.0' }
      end
    end
  end
end
