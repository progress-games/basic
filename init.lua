local function require_all(directory)
    local lfs = love.filesystem

    local function require_files(path)
        for _, item in ipairs(lfs.getDirectoryItems(path)) do
            local fullPath = path .. "/" .. item
            if lfs.getInfo(fullPath, "directory") then
                requireFiles(fullPath)
            elseif item:match("%.lua$") then
                local modulePath = fullPath:gsub("%.lua$", ""):gsub("/", ".")
                require(modulePath)
            end
        end
    end

    require_files(directory)
end

require_all(love.filesystem.getSourceBaseDirectory())