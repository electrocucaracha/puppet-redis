class redis (
  $version     = '2.8.8',
  $destination = '/opt') {

  package { 'build-essential': }

  $filename  = "redis-${version}" 
  $tar_file  = "${filename}.tar.gz"
  $url       = "http://download.redis.io/releases/${tar_file}"

  exec { "wget ${filename}":
    command => "wget -q ${url} -O ${destination}/${tar_file}",
    path => ["/usr/bin", "/bin"],
  }

  exec { "untar ${filename}":
    command => "tar -xf ${destination}/${tar_file} -C ${destination}",
    path => ["/usr/bin", "/bin"],
    subscribe => Exec["wget ${filename}"],
    refreshonly => true,
  }

  exec { "make ${tech}": 
    command  => "make",
    cwd      => "${destination}/${filename}",
    path     => ['/usr/bin', '/bin' ], 
    require => [Package['build-essential'], Exec["untar ${filename}"]],
  } 

  exec { "make install ${tech}":
    command  => "make install",
    cwd      => "${destination}/${filename}",
    path     => ['/usr/bin', '/bin' ],
    require => Exec["make ${tech}"],
  }

  file { '/etc/init/redis.conf':
    ensure  => file,
    content => template('redis/redis.conf.erb'),
  }

  service { 'redis':
    ensure   => running,
    provider => 'upstart',
    require  => [File['/etc/init/redis.conf'], Exec["make install ${tech}"]],
  }
}