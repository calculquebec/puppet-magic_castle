class profile::jupyterhub::hub (
  String $register_url = '', # lint:ignore:params_empty_string_assignment
  String $reset_pw_url = '', # lint:ignore:params_empty_string_assignment
) {
  contain jupyterhub

  Service <| tag == profile::sssd |> ~> Service['jupyterhub']
  Yumrepo['epel'] -> Class['jupyterhub']

  file { '/etc/jupyterhub/templates/login.html':
    content => epp('profile/jupyterhub/login.html', {
        'register_url' => $register_url,
        'reset_pw_url' => $reset_pw_url,
      }
    ),
  }
  include profile::slurm::submitter

  consul::service { 'jupyterhub':
    port  => 8081,
    tags  => ['jupyterhub'],
    token => lookup('profile::consul::acl_api_token'),
  }

  file { '/sbin/ipa_create_user.py':
    source => 'puppet:///modules/profile/users/ipa_create_user.py',
    mode   => '0755',
  }

# AUTOMATE THIS
# ipa role-add 'JupyterHub' --desc='JupyterHub User management'
# ipa role-add-privilege 'JupyterHub' --privilege='Group Administrators'
# ipa role-add-privilege 'JupyterHub' --privilege='User Administrators'
# ipa user-add jupyterhub --first Jupyter --last Hub
# ipa role-add-member 'JupyterHub' --users=jupyterhub
# ipa-getkeytab -p jupyterhub -k /etc/jupyterhub/jupyterhub.keytab

}

class profile::jupyterhub::node {
  if lookup('jupyterhub::node::prefix', String, undef, '') !~ /^\/cvmfs.*/ {
    include jupyterhub::node
    if lookup('jupyterhub::kernel::setup') == 'venv' and lookup('jupyterhub::kernel::venv::python') =~ /^\/cvmfs.*/ {
      Class['profile::software_stack'] -> Class['jupyterhub::kernel::venv']
    }
  }
}
