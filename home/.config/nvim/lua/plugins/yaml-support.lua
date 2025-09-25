-- Minimal YAML support - rely on LazyVim's yaml extra
return {
  -- Just add the essential schemas for Docker Compose and GitLab CI
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        yamlls = {
          settings = {
            yaml = {
              schemas = {
                -- Only the most common ones
                ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose*.yml",
                ["https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = ".gitlab-ci.yml",
              },
            },
          },
        },
      },
    },
  },
}
