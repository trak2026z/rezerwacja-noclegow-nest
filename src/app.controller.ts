// src/app.controller.ts
import { Controller, Get } from '@nestjs/common';

@Controller()
export class AppController {
  @Get('health')
  health() {
    return {
      status: 'ok',
      service: 'rezerwacja-noclegow-api',
      timestamp: new Date().toISOString(),
    };
  }
}
