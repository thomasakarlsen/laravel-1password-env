<?php

use Illuminate\Support\Facades\Route;
use App\Jobs\TestEnvJob;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/test-queue', function () {
    TestEnvJob::dispatch();
    return response('Queue job dispatched! Check the queue worker logs.');
});
