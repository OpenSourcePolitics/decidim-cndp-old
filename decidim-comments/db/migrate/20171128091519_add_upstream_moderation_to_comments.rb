class AddUpstreamModerationToComments < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_moderations, :upstream_moderation, :string, default: "unmoderate"
  end
end
