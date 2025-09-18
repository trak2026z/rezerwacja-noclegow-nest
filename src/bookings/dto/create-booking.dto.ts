// src/bookings/dto/create-booking.dto.ts
import { IsNotEmpty, IsDateString, IsNumber, Min, IsEnum } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateBookingDto {
  @ApiProperty({
    example: '60d0fe4f5311236168a109ca',
    description: 'ID pokoju do zarezerwowania',
  })
  @IsNotEmpty({ message: 'Room ID is required' })
  roomId: string;

  @ApiProperty({
    example: '2023-06-01T12:00:00Z',
    description: 'Data rozpoczęcia rezerwacji',
  })
  @IsDateString({}, { message: 'Start date must be a valid ISO date string' })
  @IsNotEmpty({ message: 'Start date is required' })
  startAt: Date;

  @ApiProperty({
    example: '2023-06-07T12:00:00Z',
    description: 'Data zakończenia rezerwacji',
  })
  @IsDateString({}, { message: 'End date must be a valid ISO date string' })
  @IsNotEmpty({ message: 'End date is required' })
  endsAt: Date;

  @ApiProperty({
    example: 500,
    description: 'Całkowita cena rezerwacji',
  })
  @IsNumber({}, { message: 'Total price must be a number' })
  @Min(0, { message: 'Total price must be a positive number' })
  @IsNotEmpty({ message: 'Total price is required' })
  totalPrice: number;

  @ApiProperty({
    example: 'pending',
    description: 'Status rezerwacji',
    enum: ['pending', 'confirmed', 'cancelled'],
    default: 'pending',
  })
  @IsEnum(['pending', 'confirmed', 'cancelled'], { message: 'Status must be one of: pending, confirmed, cancelled' })
  @IsNotEmpty({ message: 'Status is required' })
  status: string;
}
