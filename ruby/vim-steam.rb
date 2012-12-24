require "win32ole"
require "vim-steam/appcache"

module VimSteam; end

class << VimSteam
    def run(what)
        appid = resolve_appid(what)
        shell.ShellExecute("steam://run/" + appid.to_s, nil, nil, "open", 1)
    end
    
    def complete(lead)
        lead = lead.downcase
        names = appcache.names.select { |name| name.downcase.start_with?(lead) }
        VIM.command('return [' + names.map { |name| "'" + name + "'" }.join(",") + ']')
    end

    def resolve_appid(app)
        return appcache[app]
    end

    def shell
        @shell = WIN32OLE.new("Shell.Application") unless @shell
        @shell
    end

    def appcache
        @appcache = VimSteam::Appcache.new unless @appcache
        @appcache
    end
end

#  vim: set et tw=100 ts=4 sw=4:
