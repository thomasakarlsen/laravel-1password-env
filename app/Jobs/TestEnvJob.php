<?php

namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class TestEnvJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function handle()
    {
        echo "\n";
        echo "=== Queue Job: Environment Variables Loaded ===\n";
        echo "MY_VALUE: " . env('MY_VALUE', 'NOT SET') . "\n";
        echo "APP_ENV: " . env('APP_ENV', 'NOT SET') . "\n";
        echo "APP_DEBUG: " . env('APP_DEBUG', 'NOT SET') . "\n";
        echo "================================================\n";
        echo "\n";
    }
}
