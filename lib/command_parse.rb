class Parser
    @matcher = /#(?<command>\w+)(?<args>(\s?\w+)*)/

    # Implementing classes should implement this 
    #
    # Return a command and args hash
    def self.parse(string) 
        matches = string.match(@matcher)

        if matches
            { 
                command: matches['command'], 
                args: matches['args'].strip.split(' ')
            }
        else
            raise "Invalid command string #{string}"
        end
    end
end

