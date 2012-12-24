require "treetop"
require "win32/registry"

module VimSteam
    VdfParser = Treetop.load(File.join(File.dirname(__FILE__), "vdf"))

    class Appcache
        def initialize
            update
        end

        def update
            @hash = { }
            parser = VdfParser.new
            result = parser.parse(File.read(vdfpath)).value
            appdefs = result["InstallConfigStore"]["Software"]["Valve"]["Steam"]["apps"]

            appdefs.each_pair do |id, data|
                valid_app =
                    data["HasAllLocalContent"] &&
                    data["HasAllLocalContent"].to_i == 1 &&
                    data["installdir"] &&
                    !data["installdir"].index("valvetestapp") &&
                    File.exist?(data["installdir"])

                @hash[File.basename(data["installdir"])] = id.to_i if valid_app
            end
        end

        def [](name)
            return @hash[name]
        end

        def names
            @hash.keys
        end

        def steamdir
            value = nil
            begin
                Win32::Registry::HKEY_CURRENT_USER.open("Software\\Valve\\Steam") do |key|
                    value = key["SteamPath"]
                end
            rescue Win32::Registry::Error
                raise RuntimeError.new("Cannot locate steam")
            end
            value
        end

        def vdfpath
            File.join(steamdir, "config", "config.vdf")
        end
    end
end

#  vim: set et tw=100 ts=4 sw=4:
