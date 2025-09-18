// src/rooms/dto/create-room.dto.ts
import { IsNotEmpty, IsString, MinLength, MaxLength, IsOptional, IsDateString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateRoomDto {
  @ApiProperty({
    example: 'Przytulny pokój w centrum',
    description: 'Tytuł pokoju',
  })
  @IsString({ message: 'Title must be a string' })
  @IsNotEmpty({ message: 'Title is required' })
  @MinLength(5, { message: 'Title must be at least 5 characters long' })
  @MaxLength(50, { message: 'Title must not exceed 50 characters' })
  title: string;

  @ApiProperty({
    example: 'Przestronny pokój z widokiem na miasto, blisko komunikacji miejskiej.',
    description: 'Opis pokoju',
  })
  @IsString({ message: 'Body must be a string' })
  @IsNotEmpty({ message: 'Body is required' })
  @MinLength(5, { message: 'Body must be at least 5 characters long' })
  @MaxLength(500, { message: 'Body must not exceed 500 characters' })
  body: string;

  @ApiProperty({
    example: 'Warszawa',
    description: 'Miasto, w którym znajduje się pokój',
  })
  @IsString({ message: 'City must be a string' })
  @IsNotEmpty({ message: 'City is required' })
  city: string;

  @ApiProperty({
    example: 'https://picsum.photos/800/600',
    description: 'Link do obrazka pokoju',
    required: false,
  })
  @IsString({ message: 'Image link must be a string' })
  @IsOptional()
  imgLink?: string;

  @ApiProperty({
    example: '2023-06-01T12:00:00Z',
    description: 'Data rozpoczęcia rezerwacji',
    required: false,
  })
  @IsDateString({}, { message: 'Start date must be a valid ISO date string' })
  @IsOptional()
  startAt?: Date;

  @ApiProperty({
    example: '2023-06-07T12:00:00Z',
    description: 'Data zakończenia rezerwacji',
    required: false,
  })
  @IsDateString({}, { message: 'End date must be a valid ISO date string' })
  @IsOptional()
  endsAt?: Date;
}
