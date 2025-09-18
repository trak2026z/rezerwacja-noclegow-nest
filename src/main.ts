// src/main.ts
import { ValidationPipe, HttpStatus } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { Logger } from 'nestjs-pino';
import { AppModule } from './app.module';
import { ConfigService } from '@nestjs/config';
import { AllExceptionsFilter } from './filters/http-exception.filter';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { bufferLogs: true });
  app.useLogger(app.get(Logger));

  // Config
  const configService = app.get(ConfigService);
  const corsOrigin = configService.get<string>('cors.origin') || '*';
  const port = configService.get<number>('port') || 3000;

  // Globalny filtr wyjątków
  app.useGlobalFilters(new AllExceptionsFilter());

  // Globalna walidacja
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      errorHttpStatusCode: HttpStatus.UNPROCESSABLE_ENTITY,
    }),
  );

  // CORS z konfiguracji
  app.enableCors({
    origin: corsOrigin === '*' ? true : corsOrigin.split(','),
    credentials: true,
  });

  // Swagger
  const swaggerConfig = new DocumentBuilder()
    .setTitle('Rezerwacja noclegów — API')
    .setDescription('MVP API do rezerwacji noclegów w NestJS')
    .setVersion('0.0.1')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, swaggerConfig);
  SwaggerModule.setup('api', app, document);

  await app.listen(port);
  app.get(Logger).log(`App running at http://localhost:${port} (Swagger: http://localhost:${port}/api)`);
}
bootstrap();
