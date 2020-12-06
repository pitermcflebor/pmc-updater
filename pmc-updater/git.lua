local decode = assert(json.decode)
local encode = assert(json.encode)

local GH_BASE_URI = 'https://api.github.com/'
local REPOS_FORMAT_URI = GH_BASE_URI..'repos/%s/%s'

function github(gitUrl)
	gitUrl = gitUrl:gsub('https://', '')
	local components = table.build(gitUrl:split('/'))
	local repoRaw = requests.get(REPOS_FORMAT_URI:format(components[2], components[3])); assert(repoRaw)
	local repo = decode(repoRaw)
	if repo.private == true then
		printWarning('Error getting github:', gitUrl)
		printWarning('\tit was a private repo')
		return false
	else
		return setmetatable(
			{
				repo_data = repo,
			},
			{
				__tostring = function(self) return ('<GithubObject: %s>'):format(self.repo_url) end,
				__call = function(self) error'github object is not callable' end,
				__index = {
					getLastRelease = function(self)
						local uri = self.repo_data.releases_url:gsub('{/id}', '')
						local rawJson = requests.get(uri)
						if rawJson then
							return decode(rawJson)[1] or {tag_name = 'none'}
						end
					end,
					getFiles = function(self, contentUri)
						local tree = {}
						local contentRaw = requests.get(contentUri or string.gsub(self.repo_data.contents_url, '{%+path}', ''))
						if contentRaw then
							local contents = decode(contentRaw)
							for _, content in pairs(contents) do
								if not content.name:startsWith('.') and content.name ~= 'LICENSE' and content.name ~= 'README.md' then
									if content.type == 'file' then
										table.insert(tree, {path=content.path, raw=content.download_url, name=content.name})
									elseif content.type == 'dir' then
										local tree_dir = self:getFiles(content.url)
										for _, v in pairs(tree_dir) do
											table.insert(tree, v)
										end
									end
								end
							end
							return tree
						end
					end,
				}
			}
		)
	end
end
