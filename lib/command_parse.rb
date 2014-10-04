class Parser
    @matcher = /#(?<command>\w+)(?<args>.*)/

    # Implementing classes should implement this 
    #
    # Return a command and args hash
    def self.parse(string) 
        matches = string.match(@matcher)

        if matches
            { 
                command: matches['command'], 
                args: matches['args']
            }
        else
            puts "Invalid command string #{string}"
        end
    end
end

