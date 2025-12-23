<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class TestEnv extends Command
{
    protected $signature = 'test:env';
    protected $description = 'Display loaded environment variables for testing';

    public function handle()
    {
        $this->info('=== Environment Variables Loaded ===');
        $myValue = env('MY_VALUE', 'NOT SET');
        $this->line('MY_VALUE: ' . $myValue);
        $this->line('APP_ENV: ' . env('APP_ENV', 'NOT SET'));
        $this->line('APP_DEBUG: ' . env('APP_DEBUG', 'NOT SET'));
        $this->info('=====================================');
        
        $isCorrect = $myValue === 'SecretValueFrom1Password';
        $this->line('');
        
        // Display result with visual indicator
        if ($isCorrect) {
            $this->info('✓ Value is CORRECT');
        } else {
            $this->error('✗ Value is INCORRECT');
        }
        
        return $isCorrect ? 0 : 1;
    }
}
