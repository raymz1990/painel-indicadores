function twitter(handle)
  local output = '<a href="https://twitter.com/' .. pandoc.utils.stringify(handle) .. '"><i class="bi bi-twitter" ></i></a>'
  return pandoc.RawBlock('html', output)
end

function github(handle)
  local output = '<a href="https://github.com/' .. pandoc.utils.stringify(handle) .. '"><i class="bi bi-github" ></i></a>'
  return pandoc.RawBlock('html', output)
end

function scholar(handle)
  local output = '<a href="https://scholar.google.de/citations?user=' .. pandoc.utils.stringify(handle) .. '&hl=en"><i class="ai ai-google-scholar" ></i></a>'
  return pandoc.RawBlock('html', output)
end

function orcid(handle)
  local output = '<a href="https://orcid.org/' .. pandoc.utils.stringify(handle) .. '"><i class="ai ai-orcid" ></i></a>'
  return pandoc.RawBlock('html', output)
end

function researchgate(handle)
  local output = '<a href="https://researchgate.net/profile/' .. pandoc.utils.stringify(handle) .. '"><i class="ai ai-researchgate" ></i></a>'
  return pandoc.RawBlock('html', output)
end

function mastodon(url)
  local output = '<a rel="me" href="' .. pandoc.utils.stringify(url) ..'"><i class="bi bi-mastodon"></i></a>'
  return pandoc.RawBlock('html', output)
end

function linkedin(handle)
  local output = '<a href="https://www.linkedin.com/in/' .. pandoc.utils.stringify(handle) .. '"><i class="bi bi-linkedin" ></i></a>'
  return pandoc.RawBlock('html', output)
end

function email(handle)
  local output = '<a href="mailto: ' .. pandoc.utils.stringify(handle) .. '"><i class="bi bi-envelope-fill" ></i></a>'
  return pandoc.RawBlock('html', output)
end

function cv(handle)
  local output = '<a href="' .. pandoc.utils.stringify(handle) .. '"><i class="bi bi-file-earmark-person-fill"></i></a>'
  return pandoc.RawBlock('html', output)
end