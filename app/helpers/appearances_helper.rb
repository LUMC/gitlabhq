module AppearancesHelper
  def brand_item
    true
  end

  def brand_title
    'LUMC GitLab'
  end

  def brand_image
    image_tag 'lumc_logo.png'
  end

  def brand_text
    default_text =<<eos
### Welcome to the LUMC GitLab server

GitLab offers git repository management, code reviews, issue tracking,
activity feeds and wikis. This server is free to use for LUMC employees and
collaborators.

[Read more about this service and how to use
it](https://humgenprojects.lumc.nl/trac/humgenprojects/wiki/gitlab).
eos
    markdown default_text
  end
end
