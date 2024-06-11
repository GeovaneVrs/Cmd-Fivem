Commands = {}

function ensure_command(name, fn)
    local old = Commands[name]

    if not old or type(old) == 'table' then
        Commands[name] = callable(fn)
    end
end

function create_command_ref(alias, source)
    Commands[alias] = function(...)
        return Commands[source](...)
    end
end